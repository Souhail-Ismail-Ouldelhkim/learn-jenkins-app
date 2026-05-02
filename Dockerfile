# Image 1 
FROM mcr.microsoft.com/playwright:v1.39.0-jammy
RUN apt-get update && apt-get install -y jq
RUN npm install -g netlify-cli serve