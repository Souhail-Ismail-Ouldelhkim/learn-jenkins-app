pipeline {
    agent any

    stages {
        stage('Build steps') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                    mountWorkspace true  // 🔥 important
                }
            }
            steps {
                echo 'Building a new Laptop...'
                sh '''
                    mkdir -p build
                    touch build/computer.txt
                    ls -la
                    npm ci
                    npm run build
                    ls -la
                    node --version
                    npm --version
                    echo "Mainboard" >> build/computer.txt
                    cat build/computer.txt
                    echo "Display" >> build/computer.txt
                    cat build/computer.txt
                    echo "Keyboard" >> build/computer.txt
                    cat build/computer.txt
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Testing the new Laptop...'
                sh 'test -f build/computer.txt'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying the new Laptop...'
                sh '''
                    echo "Deploying computer configuration..."
                    cp build/computer.txt build/deployment_backup.txt
                    echo "Deployment complete."
                    cat build/deployment_backup.txt
                '''
            }
        }
    }

    post {
        success {
            echo 'Archiving build artifacts...'
            archiveArtifacts artifacts: 'build/*.txt', onlyIfSuccessful: true
        }

        always {
            cleanWs()
            echo 'Rebuilding the Laptop after cleanup...'
            sh '''
                mkdir -p build
                touch build/computer.txt
                echo "Mainboard" >> build/computer.txt
                cat build/computer.txt
                echo "Display" >> build/computer.txt
                cat build/computer.txt
                echo "Keyboard" >> build/computer.txt
                cat build/computer.txt
            '''
        }
    }
}
