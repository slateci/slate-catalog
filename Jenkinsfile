pipeline{
	agent any
	stages{
		stage("Build"){
			steps{
				sh 'if [ ! -d slate-catalog ]; then git clone -b automation https://github.com/slateci/slate-catalog; fi'
				dir('slate-catalog'){
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
