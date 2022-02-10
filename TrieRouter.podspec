Pod::Spec.new do |s|
	s.name     = 'TrieRouter'
	s.version  = '1.1.0'

	s.license  = { :type => 'MIT', :file => 'LICENSE' }
	s.summary  = 'An App-specific Simple Routing Library'
	s.homepage = 'https://github.com/TBXark/TrieRouter'
	s.author   = { 'TBXark' => 'tbxark@outlook.com' }
	s.source   = { :git => 'https://github.com/TBXark/TrieRouter.git', :tag => "#{s.version}" }
	s.module_name = 'TrieRouter'

	s.ios.deployment_target = '8.0'
	s.osx.deployment_target = '10.9'
	s.watchos.deployment_target = '3.0'

	s.source_files = 'Sources/TrieRouter/*.swift'
	s.framework = 'Foundation'
end