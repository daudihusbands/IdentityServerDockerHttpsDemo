docker stop webapi-demo-container
docker container rm webapi-demo-container

docker build -t webapi-demo -f src/Api/Dockerfile .

docker run -p "6001:6001" --name webapi-demo-container --rm -it `
--mount type=bind,source=/src/Api/,target=/root/Api/,readonly `
-v /src/Api/certs:/https/:rw `
-e ASPNETCORE_URLS="https://+;" `
-e ASPNETCORE_HTTPS_PORT=6001 `
-e ASPNETCORE_Kestrel__Certificates__Default__Password=password `
-e ASPNETCORE_Kestrel__Certificates__Default__Path=/https/aspnetapp-web-api.pfx `
webapi-demo

# --mount type=bind,source=./certs/aspnetapp-root-cert.cer,target=/https-root/aspnetapp-root-cert.cer `
# -v /src/Api:/root/Api:ro `
