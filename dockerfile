FROM node:20-alpine

WORKDIR /app

COPY membership-platform-dev/frontend/package*.json ./
RUN npm ci --omit=dev
COPY membership-platform-dev/frontend ./

COPY . .

EXPOSE 3000
CMD ["npm", "start"]