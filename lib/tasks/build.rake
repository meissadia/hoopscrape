namespace :build do
  desc 'Build gem.'
  task :gem do
    Rake::Task['build:readme'].execute
    `gem build hoopscrape.gemspec`
  end

  desc 'Build and install gem.'
  task :install do
    Rake::Task['build:gem'].execute
    file = `ls *.gem | head -n 1`
    puts `gem install #{file}`
  end

  desc 'Inject table of contents into README.md'
  task :readme do
    `ruby readme/generate.rb`
  end

  desc 'Prepare gem deployment.'
  task :deployment do
    Rake::Task['rubo:fix'].execute
    puts `./cc-test-reporter before-build`
    puts Rake::Task['test'].execute
    puts `./cc-test-reporter after-build --exit-code 0`
    puts Rake::Task['build:gem'].execute
  end
end

task build: ['build:install']
