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
				sh "/usr/local/bin/log-jenkins.sh ${env.JOB_NAME} ${env.BUILD_NUMBER}"
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
