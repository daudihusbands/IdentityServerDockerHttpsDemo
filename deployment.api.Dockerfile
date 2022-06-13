#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS base

WORKDIR /
RUN mkdir -p /https-root
COPY ["certs/aspnetapp-root-cert.cer", "/https-root/aspnetapp-root-cert.cer"]
# COPY ["src/Api/docker-entrypoint.sh", "/docker-entrypoint.sh"]
# RUN chmod +x docker-entrypoint.sh
# RUN sh ./docker-entrypoint.sh

RUN apt-get update
RUN apt-get install -y ca-certificates
RUN openssl x509 -inform DER -in /https-root/aspnetapp-root-cert.cer -out /https-root/aspnetapp-root-cert.crt
RUN mkdir /usr/local/share/ca-certificates/extra
RUN cp /https-root/aspnetapp-root-cert.crt /usr/local/share/ca-certificates/extra/aspnetapp-root-cert.crt
RUN dpkg-reconfigure ca-certificates
RUN update-ca-certificates

WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build
WORKDIR /src
COPY ["src/Api/Api.csproj", "src/Api/"]
RUN dotnet restore "src/Api/Api.csproj"
COPY . .
WORKDIR "/src/src/Api"
RUN dotnet build "Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Api.dll"]