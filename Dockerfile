FROM node:slim
WORKDIR /app
COPY package*.json ./
RUN ["npm", "ci", "--only=production"]
COPY dist ./
EXPOSE 80
ENTRYPOINT ["node", "index.js"]
