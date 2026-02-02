FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["StudentApi/StudentApi.csproj", "StudentApi/"]
RUN dotnet restore "StudentApi/StudentApi.csproj"
COPY . .
WORKDIR "/src/StudentApi"
RUN dotnet build "StudentApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "StudentApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "StudentApi.dll"]
