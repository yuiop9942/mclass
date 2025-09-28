pipeline 
{
    agent any // 전체 agent 대상 실행
    
    tools
    {
        maven 'maven 3.9.11' //jenkins에 등록된 maven 사용 (maven 3.9.11v)
    }

    environment
    {
        // 배포용 위한 변수 설정
        DOCKER_IMAGE = "demo-app"
        CONTAINER_NAME = "springboot-container"
        JAR_FILE_NAME = "app.jar"
        PORT = "8081"

        // 원격 서버 (Spring)
        REMOTE_USER = "ec2-user"
        REMOTE_HOST = "15.164.103.16"
        REMOTE_DIR = "/home/ec2-user/deploy"    //파일 복사 경로
        SSH_CREDENTIALS_ID = "3a10f047-ccc9-44ff-a055-d41b5e7467f9" // jenkins credentials
    }

    stages
    {
        stage('Git Checkout') 
        {
            steps 
            {  //stage에서 실행될 실제 명령어
                checkout scm    //jenkins가 연결된 git 저장소의 최신 코드 체크아웃
            }
        }
        stage('Maven Build') 
        {
            steps 
            {   // test skip and build
                sh 'mvn clean package -D skipTests'

            }
        }
        stage('Prepare Jar')
        {
            steps 
            {   // 빌드 결과물 (jar)을 지정한 이름(app.jar)으로 복사
                sh 'cp target/demo-0.0.1-SNAPSHOT.jar ${JAR_FILE_NAME}'
            }
        }
        stage('copy to remote svr Dockerfile')
        {
            steps
            {   // jenkins > spr svr로 ssh 접근을 위한 ssh agent 사용
                sshagent (credentials: [env.SSH_CREDENTIALS_ID])
                {   // 배포 디렉토리 생성 (없으면 새로 생성)
                    sh "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${REMOTE_HOST} \"mkdir -p ${REMOTE_DIR}\""
                    // JAR 파일과 Dockerfile을 원격 서버에 복사
                    sh "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${JAR_FILE_NAME} Dockerfile ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"
                }
            }
        }
        stage('remote Docker build & deploy')
        {
            steps
            {
                sshagent (credentials: [env.SSH_CREDENTIALS_ID])
                {
                    // 원격 서버에서 도커 컨테이너를 제거하고 새로 빌드 및 실행
                    // spr 서버 접속
                    // # 복사한 디렉토리로 이동
                    // # 이전에 실행 중인 컨테이너 삭제 (없으면 무시)
                    // # 현재 디렉토리에서 Docker 이미지 빌드
                    // # 새 컨테이너 실행
                    //
                    sh """
                ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${REMOTE_HOST} << ENDSSH
                    cd ${REMOTE_DIR} || exit 1 ;
                    docker rm -f ${CONTAINER_NAME} || true ;
                    docker build -t ${DOCKER_IMAGE} . ;
                    docker run -d --name ${CONTAINER_NAME} -p ${PORT}:${PORT} ${DOCKER_IMAGE}
                ENDSSH
                """
                }
            }
        }
    }
}