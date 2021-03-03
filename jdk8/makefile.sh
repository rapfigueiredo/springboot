#https://lgulliver.github.io/trivy-scan-results-to-azure-devops/
VERSION=jdk8
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
Build_Repository_Name=springboot/${VERSION}
Agent_BuildDirectory=${HOME}/azuredevops/agentpool/_work/${Build_Repository_Name}

Build_ArtifactStagingDirectory=${Agent_BuildDirectory}/a
Build_BinariesDirectory=${Agent_BuildDirectory}/b
Build_Repository_LocalPath=${Agent_BuildDirectory}/s
TestResultsDirectory=${Agent_BuildDirectory}/TestResults


mkdir -p ${Build_ArtifactStagingDirectory}
mkdir -p ${Build_BinariesDirectory}
mkdir -p ${Build_Repository_LocalPath}
mkdir -p ${TestResultsDirectory}

rm -rf ${Build_ArtifactStagingDirectory}/*;
rm -rf ${Build_BinariesDirectory}/*;
rm -rf ${Build_Repository_LocalPath}/*;
rm -rf ${TestResultsDirectory}/*;
cp -r *  ${Build_Repository_LocalPath}/;

cd ${Build_Repository_LocalPath}


IMAGE=r11o/springboot:${VERSION}

docker rmi -f ${IMAGE}

docker build --no-cache --force-rm -t ${IMAGE} . ||  exit 1

# unit test
container-structure-test test --image ${IMAGE} --config Dockerfile-unit-test.yml || exit 11

cd app
asdf local java zulu-8.52.0.23
asdf local maven 3.6.3 

CURRENT_DIR=$(pwd)
echo "BRANCH:${BRANCH}"
PROG_OPTS="--foo=bar"



MVN_OPTS="-Dbranch.name=${BRANCH} -U -Dformat=JUNIT  \
 -D${Build_Repository_Name}.version=${image_version} -U \
 -s ./settings.xml \
 -gs ./settings.xml \
 "

mvn -DtimeInMinutesPerClass=4 -DmemoryInMB=2000 -Dcores=2 compile evosuite:generate evosuite:coverage evosuite:export  ${MVN_OPTS} -Dspring-boot.run.arguments="${PROG_OPTS}" || exit 1

mvn -Djvm.arg="-Xmx2g" test jacoco:restore-instrumented-classes jacoco:report package verify   ${MVN_OPTS} -Dspring-boot.run.arguments="${PROG_OPTS}"|| exit 11



cd ..
ls -l app/target

IMAGE_APP=r11o/app:${VERSION}
#OPTIONS="-t ${IMAGE}"
OPTIONS="--no-cache --force-rm -t ${IMAGE_APP}"

docker rmi -f ${IMAGE_APP}
docker build ${OPTIONS} \
 --build-arg JAR_FILE="app/target/app*.jar" \
 --build-arg BASE_IMAGE="${IMAGE}"\
 -f Dockerfile-app . || exit 4

docker inspect ${IMAGE_APP} || exit 42

#unit test
container-structure-test test --image ${IMAGE_APP} --config Dockerfile-app-unit-test.yml || exit 5
container-structure-test test --image ${IMAGE_APP} --config entrypoint-unit-test.yml || exit 6

#Vulnerability scan
mkdir -p templates
cp -rf ~/trivy/templates/junit.tpl templates/junit.tpl
trivy image ${IMAGE_APP} || exit 7



docker rmi -f ${IMAGE_APP}
docker rmi -f ${IMAGE}
