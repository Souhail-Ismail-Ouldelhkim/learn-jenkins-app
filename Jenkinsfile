pipeline {
    agent any
    environment {
        NETLIFY_SITE_ID = '98205f75-7686-46bc-9b5d-4d9149cca3b0'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        CI_ENVIRONMENT_URL = 'https://my-jenkins-formation-deploy-netlify.netlify.app'
        REACT_APP_VERSION = '1.2.3'
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

        /*    stage('Deploy - Netlify - staging') {
                agent {
                    docker {
                        image 'node:18-alpine'
                        reuseNode true
                    }
                }
                steps {
                    sh '''
               # vide Fusion

               # DEPLOY_URL=$(grep -o "https://[a-zA-Z0-9-]*--[a-zA-Z0-9-]*\\.netlify\\.app" deploy-output.txt | head -1)
               # echo "STAGING_URL=$DEPLOY_URL" > staging-url.txt
               # cat staging-url.txt
                '''
                }
        }
*/
        stage('Deploy - E2E - staging') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.50.0'
                    reuseNode true
                }
            }
            steps {
                sh '''
            node -v
            npm install netlify-cli node-jq
            node_modules/.bin/netlify --version
            echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"

            node_modules/.bin/netlify deploy \
                --dir=build \
                --no-build \
                --site=$NETLIFY_SITE_ID \
                --auth=$NETLIFY_AUTH_TOKEN \
                --json > deploy-output.txt

            node_modules/node-jq/bin/jq -r '.deploy_url' deploy-output.txt > staging-url.txt
            cat staging-url.txt
        '''

                script {
                    def content = readFile('staging-url.txt').trim()
                    env.staging_URL = content.replace('STAGING_URL=', '')
                    env.CI_ENVIRONMENT_URL = env.staging_URL
                    echo "staging URL: ${env.staging_URL}"
                }
                sh '''
            npx playwright test --reporter=html  // après script{}
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

          /*  stage('approval')
            {
                steps
                   {
                    timeout(time: 30, unit: 'SECONDS')
                    {
                        input message: 'Ready to deploy ???', ok: 'Yes, I\'m sure to deploy'
                    }
                   }
            }*/
            // URL Fixe Toujours
            stage('Deploy - E2E - Production') {
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