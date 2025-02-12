pipeline {
    agent any
    stages {
        stage("Install Dependencies") {
            steps {
                echo "Installing Python dependencies"
                sh '''
                    # Navigate to Lambda directory
                    cd lambda
                    
                    # Create a temporary directory for the dependencies
                    mkdir -p package
                    
                    # Install dependencies from requirements.txt
                    pip install -r requirements.txt -t .
                '''
            }
        }
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
                    --function-name "ankita-ghogare-test2" \
                    --payload '{}' \
                    --log-type Tail \
                    outputfile.txt
                    cat outputfile.txt  
                '''

            }
        }
    }
}
