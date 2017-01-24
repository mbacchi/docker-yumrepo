.PHONY: build clean createrepo run prep

build: prep createrepo src
	docker build -t docker-yumrepo .

clean:
	rm -rf workdir

createrepo:
	createrepo_c workdir

run:
	docker run -d -p 80:80 docker-yumrepo

src:
	mkdir src

prep:
	mkdir workdir
	cp -r src/* workdir
