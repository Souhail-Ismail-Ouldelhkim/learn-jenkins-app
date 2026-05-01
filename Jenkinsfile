pipeline {
    agent any
    environment {
        NETLIFY_SITE_ID = '98205f75-7686-46bc-9b5d-4d9149cca3b0'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        CI_ENVIRONMENT_URL = 'https://my-jenkins-formation-deploy-netlify.netlify.app'
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {
        stage('Docker') {
            steps {
                sh 'docker build -t my-playwright .'
            }
        }
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "REACT_APP_VERSION dans E2E = $REACT_APP_VERSION"
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }

        stage('Tests') {
            parallel {
                stage('Unit tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.50.0'
                            reuseNode true
                        }
                    }
                    environment {
                        CI_ENVIRONMENT_URL = 'http://localhost:3000'
                    }
                    steps {
                        sh '''
                            echo "REACT_APP_VERSION dans E2E = $REACT_APP_VERSION"
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 60
                            echo "REACT_APP_VERSION dans E2E = $REACT_APP_VERSION"
                            npx playwright test --reporter=html
                            echo "REACT_APP_VERSION dans E2E = $REACT_APP_VERSION"
                        '''
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: false,
                                keepAll: false,
                                reportDir: 'playwright-report',
                                reportFiles: 'index.html',
                                reportName: 'Playwright Report Locally',
                                reportTitles: '',
                                useWrapperFileDirectly: true
                            ])
                        }
                    }
                }
            }
        }

        stage('Deploy - E2E - staging') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
            }
            steps {
                sh '''
            node -v
            netlify --version
            echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"

            netlify deploy \
                --dir=build \
                --no-build \
                --site=$NETLIFY_SITE_ID \
                --auth=$NETLIFY_AUTH_TOKEN \
                --json > deploy-output.json

            export CI_ENVIRONMENT_URL=$(jq -r '.deploy_url' deploy-output.json)
            echo "Staging URL: $CI_ENVIRONMENT_URL"
            npx playwright test --reporter=html
        '''
            }
            post {
                always {
                    publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: false,
                reportDir: 'playwright-report',
                reportFiles: 'index.html',
                reportName: 'Playwright staging',
                reportTitles: '',
                useWrapperFileDirectly: true
            ])
                }
            }
        }

            // URL Fixe Toujours
            stage('Deploy - E2E - Production') {
                agent {
                    docker {
                        image 'my-playwright'
                        reuseNode true
                    }
                }
                environment {
                    CI_ENVIRONMENT_URL = "${env.CI_ENVIRONMENT_URL}" // URL fixe depuis le top du pipeline
                }
                steps {
                    sh '''
                    netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy \
                        --dir=build \
                        --prod \
                        --no-build \
                        --site=$NETLIFY_SITE_ID \
                        --auth=$NETLIFY_AUTH_TOKEN
                    npx playwright test --reporter=html
                    '''
                }
                post {
                    always {
                        publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: false,
                reportDir: 'playwright-report',
                reportFiles: 'index.html',
                reportName: 'Playwright Production',
                reportTitles: '',
                useWrapperFileDirectly: true
            ])
                    }
                }
            }
    }
}
