pipeline{
	agent any
	stages{
		stage("Build"){
			steps{
				sh 'mkdir -p build'
				dir('build'){
					sh 'echo echo imaginary evil shell code > do.sh'
					sh 'chmod +x do.sh'
					sh './do.sh'
					sh 'touch /usr/share/nginx/html/catalog/flibble'
					sh 'cmake3 ..'
					sh 'make'
					script{
						if(env.BRANCH_NAME == 'master'){
							sh 'make publish'
							sh 'touch published'
						}
					}
				}
			}
		}
	}
}
