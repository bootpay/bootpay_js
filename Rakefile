require 'erb'
ROOT_PATH = `pwd`.to_s.strip
task :service do
  todo = []
  file_path = File.join(ROOT_PATH, 'config')
  Dir["#{file_path}/*.example.service"].each do |file|
    output_file = file.gsub '.example', ''
    File.open(output_file, 'wb') do |f|
      f.write ERB.new(File.read(file)).result
      f.close
    end
    print "#{output_file} 파일 생성 완료\n"
    todo << "ln -s #{output_file} #{output_file.to_s.gsub(file_path, '/lib/systemd/system')}"
    todo << "systemctl enable #{output_file.to_s.gsub(file_path, '')}"
    print "TODO: 다음 작업을 root 권한으로 반드시 해야합니다.\n#{todo.join("\n")}\n"
  end
end