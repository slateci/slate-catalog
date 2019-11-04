pipeline{
	agent any
	stages{
		stage("Build"){
			steps{
				sh 'mkdir -p build'
				dir('build'){
					sh 'cmake3 ..'
					sh 'make'
					script{
						if(env.BRANCH_NAME == 'master'){
							sh 'make publish'
						}
					}
				}
			}
		}
		stage("Log"){
			steps{
				sh 'mkdir -p /usr/share/nginx/html/buildresults/'${env.JOB_NAME}
				sh 'cp ../builds/'${env.BUILD_NUMBER}'/log /usr/share/nginx/html/buildresults/'${env.JOB_NAME}'/'${env.BUILD_NUMBER}-log.txt
			}
		}
	}
	post{
		always{
			script{
				if(currentBuild.currentResult == "FAILURE"){
					slackSend(channel: "jenkins", color: "danger", message: "${env.JOB_NAME} - ${env.BUILD_NUMBER} (Branch: ${env.GIT_BRANCH}) failed (${env.BUILD_URL})")
				}
			}
		}
	}
}
