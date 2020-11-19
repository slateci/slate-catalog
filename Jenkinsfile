pipeline{
	agent any
	stages{
		stage("Build"){
			steps{
				sh ( script: "/usr/local/bin/update_github_catalog_status pending ${env.GIT_COMMIT}" )
				sh 'mkdir -p build'
				dir('build'){
					sh 'cmake3 ..'
					sh 'make'
					script{
						sh 'printenv'
						if(env.GIT_BRANCH == 'origin/master'){
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
		success{
			if(env.GIT_BRANCH == 'origin/master')
			{
				sh ( script: "/usr/local/bin/update_github_catalog_status success ${env.GIT_COMMIT} https://jenkins.slateci.io/buildresults/catalog/${env.BUILD_ID}-log.txt" )
			}
			else 
			{
				sh ( script: "/usr/local/bin/update_github_catalog_status success ${env.GIT_COMMIT} https://jenkins.slateci.io/buildresults/${env.JOB_NAME}/${env.BUILD_NUMBER}-log.txt" )
			}
		}
		failure{
			
			if(env.GIT_BRANCH == 'origin/master')
			{
				sh ( script: "/usr/local/bin/update_github_catalog_status failure ${env.GIT_COMMIT} https://jenkins.slateci.io/buildresults/catalog/${env.BUILD_ID}-log.txt" )
			}
			else 
			{
				sh ( script: "/usr/local/bin/update_github_catalog_status failure ${env.GIT_COMMIT} https://jenkins.slateci.io/buildresults/${env.JOB_NAME}/${env.BUILD_NUMBER}-log.txt" )
			}
		}
	}
}
