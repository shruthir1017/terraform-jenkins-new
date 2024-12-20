pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/shruthir1017/terraform-jenkins-new.git'
            }
        }
        stage('Terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Plan') {
            steps {
                sh 'terraform plan -out tfplan'
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }
        stage('Apply / Destroy') {
            steps {
                script {
                    if (params.action == 'apply') {
                        if (!params.autoApprove) {
                            def plan = readFile 'tfplan.txt'
                            input message: "Do you want to apply the plan?",
                            parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                        }

                        sh "terraform apply -input=false tfplan"  // Apply the plan
                    } else if (params.action == 'destroy') {
                        // Manual approval for destroy action
                        if (!params.autoApprove) {
                            input message: "Are you sure you want to destroy all resources?",
                            parameters: [
                                text(name: 'Destroy Plan', description: 'Please review the destroy plan and confirm. Enter "yes" to proceed.', defaultValue: 'Destroying resources may result in loss of data and services.')
                            ]
                        }

                        // Ensure user input "yes" if manual approval is required for destroy
                        if (!params.autoApprove) {
                            def confirmation = input message: "Type 'yes' to confirm destruction of resources",
                            parameters: [string(defaultValue: 'no', description: 'Type "yes" to confirm destruction', name: 'Confirmation')]
                            if (confirmation != 'yes') {
                                error "Destruction not confirmed, aborting."
                            }
                        }

                        sh "terraform destroy --auto-approve"  // Destroy resources
                    } else {
                        error "Invalid action selected. Please choose either 'apply' or 'destroy'."
                    }
                }
            }
        }
    }
}
