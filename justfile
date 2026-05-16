OUTDIR := "output"
KICAD_CLI := "kicad-cli"

open:
  kicad pantsonfyre.kicad_pro

gerbers: clean gen-gerbers gen-drill zip-gerbers

svg: svg-schematic svg-pcb

drc:
  {{KICAD_CLI}} pcb drc --output --all-track-errors --schematic-parity --format=json --severity-all ./pantsonfyre.kicad_pcb

@clean:
  rm -rf "{{OUTDIR}}"

zip-gerbers:
  cd "{{OUTDIR}}/gerbers" && zip -r pantsonfyre-gerbers.zip ./pantsonfyre

svg-schematic:
  {{KICAD_CLI}} sch export svg -t arcana --output "{{OUTDIR}}" ./pantsonfyre.kicad_sch

svg-pcb:
  {{KICAD_CLI}} pcb export svg --layers '*' --mode-single -o "{{OUTDIR}}/pcb.svg" ./pantsonfyre.kicad_pcb

bom:
  {{KICAD_CLI}} sch export bom pantsonfyre.kicad_sch -o "{{OUTDIR}}/pantsonfyre-bom.csv"

@gen-gerbers:
  {{KICAD_CLI}} pcb export gerbers \
    -l B.Cu,B.Mask,B.Silkscreen,B.Paste,F.Cu,F.Mask,F.Silkscreen,F.Paste,Edge.Cuts \
    --precision 6 --no-x2 \
    --output "{{OUTDIR}}/gerbers/pantsonfyre" \
    ./pantsonfyre.kicad_pcb

@gen-drill:
  {{KICAD_CLI}} pcb export drill \
    --format excellon --drill-origin absolute \
    --excellon-zeros-format decimal --excellon-oval-format alternate --excellon-units mm --excellon-separate-th \
    --generate-map --map-format gerberx2 \
    --output "{{OUTDIR}}/gerbers/pantsonfyre" \
    ./pantsonfyre.kicad_pcb
