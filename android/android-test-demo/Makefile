.PHONY: lint ktlint format commit commit-force
lint:
	./gradlew lint

ktlint:
	./gradlew ktlintCheck

format:
	./gradlew ktlintFormat

commit:
	bash scripts/android-smart-commit.sh

commit-force:
	bash scripts/android-smart-commit.sh --force

setup:
	@echo "📋 请手动完成以下配置："
	@echo "1. 将 gradle-config.kotlin-dsl 中的内容添加到对应的 Gradle 文件"
	@echo "2. 运行 ./gradlew ktlintApplyToIdea 来配置 Android Studio"
	@echo "3. 使用 'make lint' 运行 Android Lint 检查"
	@echo "4. 使用 'make ktlint' 运行 Ktlint 检查"
	@echo "5. 使用 'make format' 自动格式化 Kotlin 代码"
