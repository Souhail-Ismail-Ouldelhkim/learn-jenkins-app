pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '98205f75-7686-46bc-9b5d-4d9149cca3b0'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        CI_ENVIRONMENT_URL = 'https://my-jenkins-formation-deploy-netlify.netlify.app'
    }

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
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
                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
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
                                reportName: 'Playwright Report Locally',
                                reportTitles: '',
                                useWrapperFileDirectly: true
                            ])
                        }
                    }
                }
            }
        }

        stage('Deploy - Netlify - Staging') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Deploying to Staging. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy \
                        --dir=build \
                        --no-build \
                        --site=$NETLIFY_SITE_ID \
                        --auth=$NETLIFY_AUTH_TOKEN

                    echo "---Contenu de fichier------"
                    cat deploy-output.txt
                '''
                script {
                    // Extraire l'URL depuis le texte
                    def deployUrl = sh(
                script: "grep -o 'https://[a-zA-Z0-9-]*\\.netlify\\.app' deploy-output.txt | head -1",
                returnStdout: true
            ).trim()
                    env.STAGING_URL = deployUrl
                    echo "Staging URL capturée: ${env.STAGING_URL}"
                }
            }
        }

        stage('E2E - Staging') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.50.0'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = "${env.STAGING_URL}"
            }
            steps {
                sh '''
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
                reportName: 'Playwright Staging',
                reportTitles: '',
                useWrapperFileDirectly: true
            ])
                }
            }
        }

        stage('Deploy - Netlify - Production') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy \
                        --dir=build \
                        --prod \
                        --no-build \
                        --site=$NETLIFY_SITE_ID \
                        --auth=$NETLIFY_AUTH_TOKEN
                '''
            }
        }

        stage('E2E - Production') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.50.0'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = "${env.CI_ENVIRONMENT_URL}" // URL fixe depuis le top du pipeline
            }
            steps {
                sh '''
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
