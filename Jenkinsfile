pipeline {
    agent any

    stages {
        stage('w/o docker') {
            steps {
                sh ''' 
                echo "Without docker"
                ls -la 
                touch container-no.txt
                '''
                /* lister le contenu qui se trouve dans le dossier ou en execute le job */
                /* directly on agent */
            }
        }

        stage('w/ docker') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode  true
                    /* agent will just download a image not install */
                }
            }
            steps {
                sh 'echo "With docker"'
                sh 'npm --version'
                sh ' ls -la '
                sh ' touch withDocker.txt '
                /* this command will be install in docker agent not jenkins principal agent */
            }
        }
    }
}
