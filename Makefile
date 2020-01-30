setup:
	docker-compose build

bundle:
	docker-compose run app bundle

serve: bundle
	docker-compose up

generate:
	docker-compose run app bin/generate

clean:
	docker-compose down --rmi all --volumes
