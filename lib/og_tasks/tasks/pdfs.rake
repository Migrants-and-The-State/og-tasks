require 'pdf-reader'
require 'vips'

namespace :pdfs do 
  desc 'spit out txt list of anums inferred from pdfs'
  task :anum_txt do
    File.open(ANUM_TXT_FILE, "w") do |file| 
      pdf_paths.map { |path| file.puts infer_anum(path) }
    end
    puts "Done ✓"
  end

  desc 'add page count to csv'
  task :page_count_csv do 
    pdf_paths.each_with_index do |path, i|
      anum = infer_anum path

      next puts "skipping #{anum}" unless records_hash.dig(anum, 'page_count').nil?
      
      page_count = deduce_page_count path
      raise "no anum #{anum} found in hash!!!" unless records_hash.key? anum
      puts "#{anum}: #{page_count} pages"

      records_hash[anum]['page_count'] = page_count
      write_to_csv(unpickle(records_hash), AFILES_CSV_FILE)
    end
  end
  
  desc 'split pdfs to jpgs'
  task :split_jpgs do
    FileUtils.mkdir_p JPG_DIR

    pdf_paths.each_with_index do |path, i|
      anum        = infer_anum path
      page_count  = Integer(records_hash.dig(anum, 'page_count') || deduce_page_count(path))
      dir         = File.join JPG_DIR, anum
     
      FileUtils.mkdir_p dir
    
      (0..page_count - 1).each do |index|
        page_num    = index.to_s.rjust(4, "0")
        page_id     = "#{anum}_#{page_num}"
        target      = File.join dir, "#{page_num}.jpg"

        next if File.file? target
  
        img = Vips::Image.pdfload path, page: index, n: 1, dpi: 300
        img = img.thumbnail_image(2500, height: 10000000) if (img.width > 2500)
        img.jpegsave target
        
        print "writing #{anum} page #{index} / #{page_count}\r"
        $stdout.flush
      end
      
      puts "finished pdf #{i+1}/#{pdf_paths.length} — process is #{(i.to_f / pdf_paths.length.to_f * 100.0).round(1)}% complete    \n"
    end
    puts "Done ✓"
  end
end