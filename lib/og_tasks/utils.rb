require 'csv'

def records
  @records ||= CSV.open(AFILES_CSV_FILE, headers: :first_row).map(&:to_h)
end

def records=(records)
  @records = records
end

def records_hash 
  @records_hash ||= pickle(records)
end

def records_hash=(records_hash)
  @records_hash = records_hash
end

def pdf_paths
  @pdfs ||= Dir.glob("#{PDF_DIR}/*.pdf")
end

def infer_anum(pdf_path)
  base = File.basename pdf_path, '.pdf'
  anum = base.match(/(A\d+)/).to_s
  anum
end

def pickle(array) 
  array.map { |r| { r['id'].strip => r } }.inject(:merge)
end

def unpickle(hash)
  hash.map { |_k, value| value }.sort_by! { |r| r['id']}
end

def write_to_csv(data, file)
  CSV.open(file, "wb") do |csv|
    csv << data.first.keys
    data.each do |hash|
      csv << hash.values
    end
  end
end

def deduce_page_count(pdf_path)
  GC.start
  PDF::Reader.new(pdf_path).page_count
end