require 'rubygems'
require 'cucumber/rake/task'
require 'selenium/rake/tasks'
require 'parallel'

# Edit the browser yaml file to specify which os/browsers you want to use
# You can use multiple files and specify which to use at runtime
browser_file = ENV['BROWSERS'] || "browsers_full.yml"

@browsers = YAML.load_file(browser_file)[:browsers]

desc "Invoke behaviours on all browsers on specified platform"
task :test do
  year, month, day = Date.today.strftime("%Y,%m,%d").split(",")
  dir = "reports/#{year}/#{month}"
  FileUtils::mkdir_p(dir)
  
  Parallel.map(@browsers, :in_processes => @browsers.count) do |browser|
    begin
      ENV['SELENIUM_BROWSER_OS'] = browser[:os]
      ENV['SELENIUM_BROWSER_NAME'] = browser[:name]
      ENV['SELENIUM_BROWSER_VERSION'] = browser[:version]
      ENV['SELENIUM_REPORT_FILENAME'] = "#{dir}/#{day}-#{browser[:os]}_#{browser[:name]}_#{browser[:version]}.html".gsub(/\s/, "_").gsub("..", ".")
      
      year, month, day = Date.today.strftime("%Y,%m,%d").split(",")
      dir = "reports/#{year}/#{month}"
      
      Rake::Task[ :run_browser_tests ].execute({ :browser_name => browser[:name],
                                                 :browser_version => browser[:version],
                                                 :browser_od => browser[:os] })
    rescue RuntimeError
      puts "Error while running task"
    end
  end    
end

Cucumber::Rake::Task.new(:'run_browser_tests') do |t|
  t.cucumber_opts = "--format pretty --format html features"
end

task :default => [:test]
