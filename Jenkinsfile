pipeline{
	agent any
	stages{
		stage("Build"){
			steps{
				sh 'mkdir -p build'
				dir('build'){
					sh "echo ${env.BRANCH_NAME}"
					sh "echo ${ghprbTargetBranch}"
					sh "echo ${ghprbSourceBranch}"
					script{
						if(env.BRANCH_NAME.startsWith('PR-')){
							sh 'status=`git diff --name-status` '+params.ghprbTargetBranch+'..'+params.ghprbSourceBranch+'''
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
