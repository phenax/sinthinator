HWDIR := "hardware"
HWOUTDIR := "hardware/output"
KICAD_CLI := "kicad-cli"

hw:
  kicad "{{HWDIR}}/sinthinator.kicad_pro"

gerbers: clean gen-gerbers gen-drill zip-gerbers

svg: svg-schematic

drc:
  {{KICAD_CLI}} pcb drc --output --all-track-errors --schematic-parity --format=json --severity-all "{{HWDIR}}/sinthinator.kicad_pcb"

@clean:
  rm -rf "{{HWOUTDIR}}"

zip-gerbers:
  cd "{{HWOUTDIR}}/gerbers" && zip -r sinthinator-gerbers.zip ./sinthinator

svg-schematic:
  {{KICAD_CLI}} sch export svg -t arcana --output . "{{HWDIR}}/sinthinator.kicad_sch"

bom:
  {{KICAD_CLI}} sch export bom "{{HWDIR}}/sinthinator.kicad_sch" -o "{{HWOUTDIR}}/sinthinator-bom.csv"

@gen-gerbers:
  {{KICAD_CLI}} pcb export gerbers \
    -l B.Cu,B.Mask,B.Silkscreen,B.Paste,F.Cu,F.Mask,F.Silkscreen,F.Paste,Edge.Cuts \
    --precision 6 --no-x2 \
    --output "{{HWOUTDIR}}/gerbers/sinthinator" \
    "{{HWDIR}}/sinthinator.kicad_pcb"

@gen-drill:
  {{KICAD_CLI}} pcb export drill \
    --format excellon --drill-origin absolute \
    --excellon-zeros-format decimal --excellon-oval-format alternate --excellon-units mm --excellon-separate-th \
    --generate-map --map-format gerberx2 \
    --output "{{HWOUTDIR}}/gerbers/sinthinator" \
    "{{HWDIR}}/sinthinator.kicad_pcb"
