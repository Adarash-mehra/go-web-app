FROM golang:latest AS base

WORKDIR /app

COPY go.mod .
# It's like pom.xml in Java, package.json in Node.js or requirements.txt in Python


RUN go mod download        
# similar to mvn dependency:resolve, npm install , pip install -r requirements.txt

COPY . .

RUN go build -o main .

FROM gcr.io/distroless/base

COPY --from=base /app/main .

COPY --from=base /app/static ./static

EXPOSE 8080

CMD [ "./main" ]
