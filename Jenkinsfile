pipeline{
    agent any 
    tools{
        gradle 'Gradle'
        }
    stages {
     /*  stage ('Software Composition Analysis'){
            steps {
              sh 'sudo dependency-check.sh --scan . -f XML -o .'
              sh 'curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token 3600b50cecd8cb3878f7eb7849c4981d2d6b9df4" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=Dependency Check Scan" -F "file=@dependency-check-report.xml;type=text/xml" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false"'  
            }    
        }*/
        stage('Static Code Analysis') {
            steps {
                    // SAST
                    sh './gradlew sonarqube \
  -Dsonar.projectKey=TX-DevSecOps \
  -Dsonar.host.url=http://192.168.6.238:9000 \
  -Dsonar.login=9c99d4f75bd01654e9545d3c32ffeafc385435fd'

            sh 'curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token cdd784dbafd645ed288c98077a837dece6b03146" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=SonarQube Scan" -F "file=@sonar_report.html;type=text/html" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false"'                                        
            }
        }
/*        stage('Build') {
            steps {
                    // for build
                    sh './gradlew clean build --no-daemon'                                        
            }
        }*/

        stage('Build'){
            steps{
                sh 'cd /home/testing/tx-web'
                sh 'docker build -t devsecops . '
                sh 'docker tag devsecops:latest pritidevops/devsecops'
                withDockerRegistry([ credentialsId: "Dockerhub", url: "" ]) 
                {
                sh  'docker push pritidevops/devsecops'
                }
            }
        }

        stage('Unit Testing') {
            steps{
                    junit(testResults: 'build/test-results/test/*.xml', allowEmptyResults : true, skipPublishingChecks: true)
            }
            post {
                success {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'build/reports/tests/test/', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', useWrapperFileDirectly: true])
        }
      }
    }

        stage ('Staging') {
            steps {
                sshPublisher(publishers: [sshPublisherDesc(configName: 'docker-staging', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'docker rm -f devsecops-test | echo "No container exits with 'devsecops-test' name" && docker pull pritidevops/devsecops && docker run -itd -p 9090:9090 --name devsecops-test pritidevops/devsecops:latest', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'vulnerable-staging', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '**/*')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])            
            }
        }
        stage ('DAST') {
            steps {
                sh 'curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token c50c94737824e0bd561315ce8ee856849f5ba88f" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=Acunetix Scan" -F "file=@scan_report_dast.xml;type=text/xml" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false"'
            }
        } 
        stage ('Docker Scan') {
            steps {
               sshPublisher(publishers: [sshPublisherDesc(configName: 'docker-staging', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'trivy image --format json -o scan_report2.json sasanlabs/owasp-vulnerableapp-jsp && curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token c50c94737824e0bd561315ce8ee856849f5ba88f" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=Trivy Scan" -F "file=@scan_report2.json;type=application/json" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false" && trivy image --format json -o scan_report3.json sasanlabs/owasp-vulnerableapp-php && curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token c50c94737824e0bd561315ce8ee856849f5ba88f" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=Trivy Scan" -F "file=@scan_report3.json;type=application/json" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false" && trivy image --format json -o scan_report4.json sasanlabs/owasp-vulnerableapp-facade && curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token c50c94737824e0bd561315ce8ee856849f5ba88f" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=Trivy Scan" -F "file=@scan_report4.json;type=application/json" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false"', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
        }
        stage ('Prod-Approval') {
            steps {
                input "Deploy to prod?"
            }
        }

        stage ('Production') {
            steps {
                sshPublisher(publishers: [sshPublisherDesc(configName: 'docker-production', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'docker rm -f devsecops-prod | echo "No container exits with 'devsecops-prod' name" && docker pull pritidevops/devsecops && docker run -itd -p 9090:9090 --name devsecops-prod pritidevops/devsecops:latest --name devsecops-prod', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'vulnerable-prod', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '**/*')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])            
            }
        } 
    }
}
