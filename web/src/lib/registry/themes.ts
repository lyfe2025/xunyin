export type Theme = {
  name: string
  label: string
  activeColor: string
  cssVars: {
    light: Record<string, string>
    dark: Record<string, string>
  }
}

export const themes: Theme[] = [
  {
    name: 'zinc',
    label: 'Zinc',
    activeColor: 'oklch(0.205 0 0)',
    cssVars: {
      light: {
        '--primary': 'oklch(0.205 0 0)',
        '--primary-foreground': 'oklch(0.985 0 0)',
        '--ring': 'oklch(0.708 0 0)',
      },
      dark: {
        '--primary': 'oklch(0.985 0 0)',
        '--primary-foreground': 'oklch(0.205 0 0)',
        '--ring': 'oklch(0.556 0 0)',
      },
    },
  },
  {
    name: 'red',
    label: 'Red',
    activeColor: 'oklch(0.577 0.245 27.325)',
    cssVars: {
      light: {
        '--primary': 'oklch(0.577 0.245 27.325)',
        '--primary-foreground': 'oklch(0.985 0 0)',
        '--ring': 'oklch(0.577 0.245 27.325)',
      },
      dark: {
        '--primary': 'oklch(0.65 0.24 27.325)', // Lighter red for dark mode
        '--primary-foreground': 'oklch(0.985 0 0)',
        '--ring': 'oklch(0.65 0.24 27.325)',
      },
    },
  },
  {
    name: 'blue',
    label: 'Blue',
    activeColor: 'oklch(0.5 0.25 260)',
    cssVars: {
      light: {
        '--primary': 'oklch(0.488 0.243 264.376)', // Blue 600
        '--primary-foreground': 'oklch(0.985 0 0)',
        '--ring': 'oklch(0.488 0.243 264.376)',
      },
      dark: {
        '--primary': 'oklch(0.6 0.2 264.376)', // Blue 500/400
        '--primary-foreground': 'oklch(0.985 0 0)',
        '--ring': 'oklch(0.6 0.2 264.376)',
      },
    },
  },
  {
    name: 'green',
    label: 'Green',
    activeColor: 'oklch(0.55 0.2 145)',
    cssVars: {
      light: {
        '--primary': 'oklch(0.546 0.245 142.495)', // Green 600
        '--primary-foreground': 'oklch(0.985 0 0)',
        '--ring': 'oklch(0.546 0.245 142.495)',
      },
      dark: {
        '--primary': 'oklch(0.65 0.2 142.495)', // Green 500
        '--primary-foreground': 'oklch(0.985 0 0)',
        '--ring': 'oklch(0.65 0.2 142.495)',
      },
    },
  },
  {
    name: 'orange',
    label: 'Orange',
    activeColor: 'oklch(0.6 0.2 50)',
    cssVars: {
      light: {
        '--primary': 'oklch(0.627 0.194 46.677)', // Orange 600
        '--primary-foreground': 'oklch(0.985 0 0)',
        '--ring': 'oklch(0.627 0.194 46.677)',
      },
      dark: {
        '--primary': 'oklch(0.7 0.15 46.677)', // Orange 500
        '--primary-foreground': 'oklch(0.985 0 0)',
        '--ring': 'oklch(0.7 0.15 46.677)',
      },
    },
  },
  {
    name: 'yellow',
    label: 'Yellow',
    activeColor: 'oklch(0.75 0.18 85)',
    cssVars: {
      light: {
        '--primary': 'oklch(0.76 0.17 85)', // Yellow 500-ish
        '--primary-foreground': 'oklch(0.205 0 0)', // Dark text for yellow
        '--ring': 'oklch(0.76 0.17 85)',
      },
      dark: {
        '--primary': 'oklch(0.82 0.15 85)',
        '--primary-foreground': 'oklch(0.205 0 0)',
        '--ring': 'oklch(0.82 0.15 85)',
      },
    },
  },
  {
    name: 'violet',
    label: 'Violet',
    activeColor: 'oklch(0.5 0.25 290)',
    cssVars: {
      light: {
        '--primary': 'oklch(0.5 0.25 290)', // Violet 600
        '--primary-foreground': 'oklch(0.985 0 0)',
        '--ring': 'oklch(0.5 0.25 290)',
      },
      dark: {
        '--primary': 'oklch(0.65 0.2 290)',
        '--primary-foreground': 'oklch(0.985 0 0)',
        '--ring': 'oklch(0.65 0.2 290)',
      },
    },
  },
]
