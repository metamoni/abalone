class ImportCohortsJob < ApplicationJob
  def perform(upload)
    @status = { created_count: 0, error_count: 0, errors: [] }
    line_number = 1
    CSV.parse(upload.file.download, headers: true) do |row|
      line_number += 1
      cohort = Cohort.new(cohort_params(row, upload.organization))

      if cohort.save
        @status[:created_count] += 1
      else
        @status[:errors] << { row: row.to_s.chomp, row_num: line_number, msg: cohort.errors.messages }
        @status[:error_count] += 1
      end
    end
    upload.update(status: job_status)
  end

  private

  def job_status
    "Completed. Created #{@status[:created_count]} enclosures.\n"\
    "#{@status[:error_count]} records had errors:\n#{error_messages}"
  end

  def error_messages
    @status[:errors].map do |err|
      "Row ##{err[:row_num]} | #{err[:row]} had the following errors: #{err[:msg]}"
    end.join('\n')
  end

  def cohort_params(params, organization)
    {
      name: params['name'],
      female: Animal.new(tag: params['female_tag'], sex: 'female', organization: organization),
      male: Animal.new(tag: params['male_tag'], sex: 'male', organization: organization),
      enclosure: Enclosure.for_organization(organization).find_by(name: params['enclosure']),
      organization: organization
    }
  end
end
