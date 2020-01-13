setup:
	docker-compose build

bundle:
	docker-compose run app bundle

serve: bundle
	docker-compose up

clean:
	docker-compose down --rmi all --volumes
