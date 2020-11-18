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
						sh 'printenv'
						if(env.env.GIT_BRANCH == 'origin/master'){
							sh 'make publish'
						}
					}
				}
			}
		}
	}
	post{
		always{
			script{
				RESULTS_URL = sh (
					script: "/usr/local/bin/log-jenkins.sh ${env.JOB_NAME} ${env.BUILD_NUMBER} ${currentBuild.currentResult}",
					returnStdout: true
				).trim()
				if(currentBuild.currentResult == "FAILURE"){
					slackSend(channel: "jenkins", color: "danger", message: "${env.JOB_NAME} - ${env.BUILD_NUMBER} (Branch: ${env.GIT_BRANCH}) failed (${RESULTS_URL})")
				}
			}
		}
	}
}
