require 'yaml'

CONFIG          = YAML.load_file 'config.yml'
RW_DIR          = File.dirname CONFIG['source_dir']
PDF_DIR         = File.join RW_DIR, 'pdfs'
JPG_DIR         = File.join RW_DIR, 'jpgs'
ANUM_TXT_FILE   = File.join RW_DIR, 'anumbers.txt'
AFILES_CSV_FILE = CONFIG.dig 'records', 'file'