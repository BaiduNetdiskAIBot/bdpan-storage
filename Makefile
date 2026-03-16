.PHONY: help list pack pack-all clean

# 项目配置
SKILLS_DIR := skills
OUTPUT_DIR := dist

# 颜色定义
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# 默认目标
help:
	@echo "📦 Skill 打包工具"
	@echo ""
	@echo "用法:"
	@echo "  make list              列出所有可用的 skills"
	@echo "  make pack SKILL=name   打包指定的 skill"
	@echo "  make pack-all          打包所有 skills"
	@echo "  make clean             清理打包输出"
	@echo ""
	@echo "示例:"
	@echo "  make pack SKILL=bdpan-storage"
	@echo "  make pack SKILL=bdpan-storage OVERWRITE=1"

# 列出所有 skills
list:
	@echo "$(BLUE)可用的 Skills:$(NC)"
	@echo ""
	@for skill_path in $(SKILLS_DIR)/*/; do \
		if [ -d "$$skill_path" ]; then \
			skill_name=$$(basename "$$skill_path"); \
			if [ -f "$$skill_path/SKILL.md" ]; then \
				echo "  ✓ $$skill_name"; \
			else \
				echo "  ⚠ $$skill_name (缺少 SKILL.md)"; \
			fi \
		fi \
	done
	@echo ""

# 打包单个 skill
pack:
	@if [ -z "$(SKILL)" ]; then \
		echo "$(RED)❌ 错误: 请指定 SKILL 参数$(NC)"; \
		echo "用法: make pack SKILL=skill-name"; \
		exit 1; \
	fi
	@if [ ! -d "$(SKILLS_DIR)/$(SKILL)" ]; then \
		echo "$(RED)❌ 错误: Skill '$(SKILL)' 不存在$(NC)"; \
		$(MAKE) list; \
		exit 1; \
	fi
	@mkdir -p $(OUTPUT_DIR)
	$(eval VERSION := $(shell cat $(SKILLS_DIR)/$(SKILL)/VERSION 2>/dev/null || echo "unknown"))
	$(eval ZIP_NAME := $(SKILL)-$(VERSION).zip)
	@if [ -f "$(OUTPUT_DIR)/$(ZIP_NAME)" ] && [ -z "$(OVERWRITE)" ]; then \
		echo "$(YELLOW)⚠️  $(OUTPUT_DIR)/$(ZIP_NAME) 已存在$(NC)"; \
		echo "使用 OVERWRITE=1 覆盖"; \
		exit 1; \
	fi
	@echo "$(BLUE)📦 正在打包: $(SKILL) v$(VERSION)$(NC)"
	@cd $(SKILLS_DIR) && zip -r "../$(OUTPUT_DIR)/$(ZIP_NAME)" "$(SKILL)" \
		-x "*/.git/*" "*/.DS_Store" "*/node_modules/*" "*/__pycache__/*" \
		-x "*/.env*" "*/.idea/*" "*/.vscode/*" "*/dist/*" "*/build/*" \
		-x "*.pyc" "*.log" "*.tmp" "*.swp" -q
	@echo "$(GREEN)✅ 打包成功: $(OUTPUT_DIR)/$(ZIP_NAME)$$(du -h $(OUTPUT_DIR)/$(ZIP_NAME) | cut -f1 | xargs -I {} echo ' ({}')$(NC)"
	@echo ""
	@echo "包内文件:"
	@unzip -l "$(OUTPUT_DIR)/$(ZIP_NAME)" | tail -n +4 | grep -v "^$$" | grep -v "^--------" | awk '{print "  " $$4}' | head -15
	@file_count=$$(unzip -l "$(OUTPUT_DIR)/$(ZIP_NAME)" | grep -c "^.*[0-9].*$(SKILL)" || echo 0); \
	if [ "$$file_count" -gt 15 ]; then \
		echo "  ... 还有 $$(($$file_count - 15)) 个文件"; \
	fi

# 打包所有 skills
pack-all:
	@echo "$(BLUE)📦 打包所有 skills...$(NC)"
	@echo ""
	@mkdir -p $(OUTPUT_DIR)
	@for skill_path in $(SKILLS_DIR)/*/; do \
		if [ -d "$$skill_path" ]; then \
			skill_name=$$(basename "$$skill_path"); \
			$(MAKE) pack SKILL=$$skill_name OVERWRITE=1; \
			echo ""; \
		fi \
	done
	@echo "$(GREEN)✅ 所有 skills 打包完成$(NC)"
	@echo "输出目录: $(OUTPUT_DIR)/"
	@ls -lh $(OUTPUT_DIR)/*.zip 2>/dev/null || echo "暂无打包文件"

# 清理输出目录
clean:
	@rm -rf $(OUTPUT_DIR)/
	@echo "$(GREEN)✅ 已清理 $(OUTPUT_DIR)/ 目录$(NC)"
