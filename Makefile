# 幻灯片与独立 TikZ 图的构建规则。
#
#   make          # 构建 slide.pdf；只重新编译有改动的独立 TikZ 图
#   make figures  # 只构建 tikz/ 下的图
#   make clean    # 删除生成的文件
#
# 依赖：xelatex、latexmk。请在项目根目录执行 make。

MAIN     := slide
FIG_DIR  := tikz

LATEXMK ?= /usr/bin/latexmk

# latexmk 用绝对路径调用；同时显式导出 PATH，确保它调用的
# xelatex、bibtex、xdvipdfmx 等也能被找到。
export PATH := /usr/bin:/usr/local/bin:/usr/local/sbin:$(PATH)

LATEX_FLAGS := -xelatex -interaction=nonstopmode -halt-on-error

# 公共导言区不是图，不要为它生成 PDF。
FIG_TEX := $(filter-out $(FIG_DIR)/fig-preamble.tex,$(wildcard $(FIG_DIR)/*.tex))
FIG_PDF := $(FIG_TEX:.tex=.pdf)

MAIN_DEPS := $(MAIN).tex packages.tex macros.tex Tsinghua.sty \
             $(wildcard pic/*) $(FIG_PDF)

.PHONY: all figures clean

all: $(MAIN).pdf

figures: $(FIG_PDF)

$(MAIN).pdf: $(MAIN_DEPS)
	$(LATEXMK) $(LATEX_FLAGS) $(MAIN).tex

# 只有图自身的 .tex 或公共导言区变化时，才重新编译该图。
# standalone 会按 TikZ 的包围盒裁剪页面，因此 PDF 尺寸与原图一致。
$(FIG_DIR)/%.pdf: $(FIG_DIR)/%.tex $(FIG_DIR)/fig-preamble.tex \
                  packages.tex macros.tex
	$(LATEXMK) $(LATEX_FLAGS) -outdir=$(FIG_DIR) $<

clean:
	$(LATEXMK) -C $(MAIN).tex
	for f in $(FIG_TEX); do $(LATEXMK) -C -outdir=$(FIG_DIR) $$f; done
	rm -f $(FIG_PDF)
