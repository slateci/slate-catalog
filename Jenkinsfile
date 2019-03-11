pipeline{
	agent any
	stages{
		stage("Build"){
			steps{
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
