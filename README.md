# cursor-view-docker
Dockerfile for cursor-view: https://github.com/saharmor/cursor-view

## Step 1. Clone cursor-view
```
git clone https://github.com/saharmor/cursor-view
```

## Step 2. Clone cursor-view-docker and copy Dockerfile
```
git clone https://github.com/marib00/cursor-view-docker
cp cursor-view-docker/Dockerfile cursor-view/
```

## Step 3. Build docker image
```
cd cursor-view
docker build -t cursor-view .
```

## Step 4. Run
```
# MacOS, adjust -v accordingly for Windows or Linux
docker run -p 5001:5000 -v ~/Library/Application\ Support/Cursor:/root/.config/Cursor --name cursor-view cursor-view
```

## Step 5. Enjoy!

http://localhost:5001
