.PHONY: up
up: ## Поднять контейнеры (detached)
	@echo "🚀 Поднимаем контейнеры (detached)..."
	docker compose up -d --build

.PHONY: up-follow
up-follow: ## Поднять контейнеры с логами
	@echo "📡 Поднимаем контейнеры (в консоли)..."
	docker compose up --build

.PHONY: down
down: ## Остановить и удалить контейнеры
	@echo "🛑 Останавливаем и удаляем контейнеры..."
	docker compose down

.PHONY: reload
reload: ## Перезапустить контейнеры (detached)
	@$(MAKE) down
	@$(MAKE) up

.PHONY: reload-follow
reload-follow: ## Перезапустить контейнеры с логами
	@$(MAKE) down
	@$(MAKE) up-follow

.PHONY: exec
exec: ## Зайти в контейнер бота (интерактивная сессия)
	docker exec -it remnawave_bot /bin/bash

.PHONY: alembic
alembic: ## Выполнить alembic команду (пример: make alembic CMD="upgrade head")
	docker exec -it remnawave_bot alembic $(CMD)

.PHONY: migration
migration: ## Создать миграцию (пример: make migration m="add_system_settings_table")
	@if [ -z "$(m)" ]; then \
		echo "❌ Ошибка: укажите сообщение для миграции, например: make migration m='add column'"; \
		exit 1; \
	fi
	docker exec -it remnawave_bot alembic revision --autogenerate -m "$(m)"

.PHONY: migrate
migrate: ## Применить все неприменённые миграции
	docker exec -it remnawave_bot alembic upgrade head

.PHONY: migrate-stamp
migrate-stamp: ## Пометить БД как актуальную (для существующих БД)
	docker exec -it remnawave_bot alembic stamp head

.PHONY: migrate-history
migrate-history: ## Показать историю миграций
	docker exec -it remnawave_bot alembic history --verbose

.PHONY: test
test: ## Запустить тесты внутри контейнера
	docker exec -it remnawave_bot pytest -v

.PHONY: lint
lint: ## Проверить код (ruff check) внутри контейнера
	docker exec -it remnawave_bot ruff check .

.PHONY: format
format: ## Форматировать код (ruff format) внутри контейнера
	docker exec -it remnawave_bot ruff format .

.PHONY: fix
fix: ## Исправить код (ruff check --fix + format) внутри контейнера
	docker exec -it remnawave_bot ruff check . --fix
	docker exec -it remnawave_bot ruff format .

.PHONY: help
help: ## Показать список доступных команд
	@echo ""
	@echo "📘 Команды Makefile:"
	@echo ""
	@awk -F':.*## ' '/^[a-zA-Z0-9_-]+:.*## / {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
