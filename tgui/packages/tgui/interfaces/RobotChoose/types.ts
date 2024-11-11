export type Data = {
  possible_modules: string[];
  possible_sprites?: spriteOption[];
  currentName: string;
  theme?: string;
  selected_module?: string;
  sprite_datum?: string | null;
  sprite_datum_class?: string | null;
  sprite_datum_size?: string | null;
};

export type spriteOption = { sprite: string; belly: boolean; type: string };
