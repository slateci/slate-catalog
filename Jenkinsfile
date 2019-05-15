pipeline{
	agent any
	stages{
		stage("Build"){
			steps{
				sh 'mkdir -p build'
				dir('build'){
					sh "echo ${env.BRANCH_NAME}"
					script{
						if(env.BRANCH_NAME.startsWith('PR-')){
							sh "echo ${env.CHANGE_TARGET}"
							sh "echo ${env.CHANGE_BRANCH}"
							sh '''status=`git diff --name-status` ${CHANGE_TARGET}..${CHANGE_BRANCH}
							for protected in Jenkinsfile CMakeLists.txt; do
								if echo "$status" | grep "$protected"; then
									echo "Changes to protected file ${protected}; cowardly refusing to continue"
									exit 1
								fi
							done
							'''
						}
					}
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
	}
}
