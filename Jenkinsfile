pipeline {
    agent any

    environment {
        TF_DIR = 'infra/terraform'
        APP_DIR = 'app/invento-app'
        SKIP_TF = 'false'
        REPORT_DIR = 'reports'
        ANSIBLE_DIR = 'infra/ansible'
    }

    stages {
        stage('🔐 Checkout Terraform Code') {
            steps {
                dir('infra') {
                    git credentialsId: 'github-creds', url: 'https://github.com/AnujPawaadia/InventoWare-Infra.git', branch: 'main'
                }
            }
        }

        stage('🔐 Checkout Application Code') {
            steps {
                dir('app') {
                    git credentialsId: 'github-creds', url: 'https://github.com/AnujPawaadia/InventoWare-Cloud-Migration.git', branch: 'main'
                }
            }
        }

        stage('🧭 Check Existing Infra') {
            steps {
                script {
                    def instanceCheck = sh(
                        script: '''
                            docker run --rm \
                              -v $HOME/.aws:/root/.aws \
                              amazon/aws-cli ec2 describe-instances \
                              --filters "Name=tag:Name,Values=InventoWareApp" \
                              --region eu-north-1 \
                              --query "Reservations[*].Instances[*].InstanceId" \
                              --output text
                        ''',
                        returnStdout: true
                    ).trim()
                    if (instanceCheck) {
                        echo "✅ Instance found: ${instanceCheck} — Skipping Terraform."
                        env.SKIP_TF = 'true'
                    } else {
                        echo "🚧 No existing instance — Proceeding with Terraform."
                        env.SKIP_TF = 'false'
                    }
                }
            }
        }

        stage('🔧 Terraform Init') {
            when { expression { env.SKIP_TF == 'false' } }
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('🧪 Terraform Validate') {
            when { expression { env.SKIP_TF == 'false' } }
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('📋 Terraform Plan') {
            when { expression { env.SKIP_TF == 'false' } }
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform plan -out=tfplan.out'
                }
            }
        }

        stage('🚀 Terraform Apply') {
            when { expression { env.SKIP_TF == 'false' } }
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -auto-approve tfplan.out'
                }
            }
        }

        stage('📤 Terraform Output') {
            when { expression { env.SKIP_TF == 'false' } }
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform output'
                }
            }
        }

        stage('✅ Linting') {
            steps {
                dir("${APP_DIR}") {
                    sh '''
                        docker run --rm -v $PWD:/app -w /app python:3.11-slim bash -c "
                            pip install flake8 black &&
                            flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics &&
                            black --check .
                        "
                    '''
                }
            }
        }

        stage('🧪 Unit Tests') {
            when { expression { return false } }
            steps {
                echo "⏭️ Skipping Unit Tests"
            }
        }

        stage('🔎 SonarCloud Scan') {
            steps {
                dir("${APP_DIR}") {
                    withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            echo "🔍 Running SonarQube Scanner..."
                            mkdir -p ../reports
                            docker run --rm \
                              -v "$(pwd):/usr/src" \
                              sonarsource/sonar-scanner-cli:latest \
                              sonar-scanner \
                              -Dsonar.projectKey=inventoware \
                              -Dsonar.sources=. \
                              -Dsonar.host.url=https://sonarcloud.io \
                              -Dsonar.organization=arjun02bh \
                              -Dsonar.login=$SONAR_TOKEN \
                              -Dsonar.python.coverage.reportPaths=coverage.xml \
                            | tee ../reports/sonar-report.txt
                        '''
                    }
                }
            }
        }

        stage('🐳 Build & Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_TOKEN')]) {
                    dir("${APP_DIR}") {
                        sh '''
                            echo $DOCKERHUB_TOKEN | docker login -u $DOCKERHUB_USERNAME --password-stdin
                            IMAGE=$DOCKERHUB_USERNAME/inventoware-app
                            TAG=$(git rev-parse --short HEAD)
                            docker build -t $IMAGE:$TAG .
                            docker tag $IMAGE:$TAG $IMAGE:latest
                            docker tag $IMAGE:$TAG $IMAGE:previous
                            docker push $IMAGE:$TAG
                            docker push $IMAGE:latest
                            docker push $IMAGE:previous
                        '''
                    }
                }
            }
        }

        stage('🔍 Trivy Scan') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_TOKEN')]) {
                    sh '''
                        mkdir -p reports
                        IMAGE=$DOCKERHUB_USERNAME/inventoware-app
                        docker pull $IMAGE:latest
                        docker run --rm \
                          -v /var/run/docker.sock:/var/run/docker.sock \
                          -v "$(pwd)/reports:/root/reports" \
                          aquasec/trivy:latest \
                          image --exit-code 0 --severity HIGH,CRITICAL --format table $IMAGE:latest > reports/trivy-report.txt
                    '''
                }
            }
        }

        stage('📦 Run Ansible Provisioning') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                        if ! command -v ansible-playbook &> /dev/null; then
                            echo "🔧 Installing Ansible..."
                            sudo apt update && sudo apt install -y ansible
                        fi

                        echo "🚀 Running Ansible..."
                        ansible-playbook -i inventory.ini playbook-blue.yml
                        ansible-playbook -i inventory.ini playbook-green.yml
                        ansible-playbook -i inventory.ini playbook-monitoring.yml
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'reports/*.txt', allowEmptyArchive: true
        }

        success {
            emailext (
                subject: "✅ SUCCESS: InventoWarePipeline #${BUILD_NUMBER}",
                body: """<p>Hello Team,</p>
                         <p>The Jenkins pipeline <strong>succeeded</strong>.</p>
                         <p>Trivy and SonarCloud reports are attached.</p>
                         <p><a href=\"${BUILD_URL}\">View Pipeline</a></p>
                         <p>Regards,<br>InventoWare DevOps</p>""",
                mimeType: 'text/html',
                to: 'arjunsharma08meerut@gmail.com, anuj.107126@stu.upes.ac.in',
                from: 'fgrreloadedprogrammer@gmail.com',
                attachLog: true,
                attachmentsPattern: 'reports/*.txt'
            )
        }

        failure {
            emailext (
                subject: "❌ FAILURE: InventoWarePipeline #${BUILD_NUMBER}",
                body: """<p>Hello Team,</p>
                         <p>The Jenkins pipeline <strong>failed</strong>.</p>
                         <p>Please check attached reports and Jenkins logs.</p>
                         <p><a href=\"${BUILD_URL}\">View Pipeline</a></p>
                         <p>Regards,<br>InventoWare DevOps</p>""",
                mimeType: 'text/html',
                to: 'arjunsharma08meerut@gmail.com, anuj.107126@stu.upes.ac.in',
                from: 'fgrreloadedprogrammer@gmail.com',
                attachLog: true,
                attachmentsPattern: 'reports/*.txt'
            )
        }
    }
}
