pipeline{
	agent any
	stages{
		stage("Build"){
			steps{
				sh 'if [ ! -d slate-catalog-new ]; then git clone git://jenkins.slateci.io:9418/slate-catalog-new; fi'
				dir('slate-catalog-new'){
					sh 'git pull'
					sh 'mkdir -p build'
					dir('build'){
						sh 'cmake3 ..'
						sh 'make'
						sh 'make publish'
					}
				}
			}
		}
	}
}
