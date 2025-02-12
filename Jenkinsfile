pipeline {
    agent any
    stages {
        stage("TF Init") {
            steps {
                echo "Executing Terraform Init"
                sh 'terraform init'
            }
        }
        stage("TF Validate") {
            steps {
                echo "Validating Terraform Code"
                sh 'terraform validate'
            }
        }
        stage("TF Plan") {
            steps {
                echo "Executing Terraform Plan"
                sh 'terraform plan'
            }
        }
        stage("TF Apply") {
            steps {
                echo "Executing Terraform Apply"
                sh 'terraform apply -auto-approve'
            }
        }
        stage("Invoke Lambda") {
            steps {
                echo "Invoking your AWS Lambda"
                sh '''
                    aws lambda invoke \
                    --function-name "ankita-ghadage-test" \  # Replace with your actual Lambda function name (no spaces) 
                    --payload '{}' \
                    --log-type Tail \
                    outputfile.txt
                    cat outputfile.txt  
                '''
            }
        }
    }
}
