require 'aws-sdk-s3'
require 'dotenv'

TIF_DIR     = './build/image/'
JSON_DIR    = './build/presentation/'

Dotenv.load

def credentials
  @credentials ||= Aws::Credentials.new ENV['ACCESS_KEY_ID'], ENV['SECRET_ACCESS_KEY']
end 

def s3
  @s3 ||= Aws::S3::Client.new(region: ENV['REGION'], credentials: credentials)
end

namespace :s3 do
  namespace :push do
    desc 'sync local tifs to s3'
    task :tifs do
      Dir.glob("#{TIF_DIR}/*.tif").each do |path|
        key = File.basename path
        s3.put_object({
          bucket: ENV['IMAGE_BUCKET_NAME'],
          key: key,
          content_type: 'image/tiff',
          content_disposition: 'inline',
          acl: 'public-read',
          body: File.read(path)
        })
        puts "uploaded #{key}"
      end
    end

    desc 'sync local json to s3'
    task :json do
      Dir.glob("#{JSON_DIR}/**/*.json").each do |path|
      key = path.sub "#{JSON_DIR}/", ''
      s3.put_object({
        bucket: ENV['PRESENTATION_BUCKET_NAME'],
        key: key,
        content_type: 'application/json',
        content_disposition: 'inline',
        acl: 'public-read',
        body: File.read(path)
      })
      puts "uploaded #{key}"
    end
    end
  end
  namespace :clobber do
    desc 'clears out og tifs in s3 bucket'
    task :tifs do
      puts 'TO DO'
    end

    desc 'clears out og json in s3 bucket'
    task :json do
      puts 'TO DO'
    end
  end
end