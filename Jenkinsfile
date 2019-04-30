pipeline {
    agent {
        node {
            label 'master'
        }
    }

    stages {

        stage('terraform started') {
            steps {
                sh 'echo "Started...!" '
            }
        }
        stage('git clone') {
            steps {
                sh 'sudo rm -r *;sudo git clone https://github.com/PraveenkumarDhavamani/AWS-Terrafrom-Demo.git'
            }
        }
        stage('terraform init') {
            steps {
                sh 'sudo /opt/terraform init ./AWS-Terrafrom-Demo'
            }
        }
        stage('terraform plan') {
            steps {
                sh 'ls ./AWS-Terrafrom-Demo; sudo /opt/terraform plan ./AWS-Terrafrom-Demo'
            }
        }
        stage('terraform ended') {
            steps {
                sh 'echo "Successfully completed!!"'
            }
        }

        
    }
}
