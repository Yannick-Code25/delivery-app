---
name: Vibrant Velocity
colors:
  surface: '#f8fafb'
  surface-dim: '#d8dadb'
  surface-bright: '#f8fafb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f5'
  surface-container: '#eceeef'
  surface-container-high: '#e6e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#504534'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#eff1f2'
  outline: '#827562'
  outline-variant: '#d4c4ae'
  surface-tint: '#7c5800'
  primary: '#7c5800'
  on-primary: '#ffffff'
  primary-container: '#ffc244'
  on-primary-container: '#715000'
  inverse-primary: '#f9bd3f'
  secondary: '#595f6a'
  on-secondary: '#ffffff'
  secondary-container: '#dde2f0'
  on-secondary-container: '#5f6570'
  tertiary: '#006b56'
  on-tertiary: '#ffffff'
  tertiary-container: '#66e1bf'
  on-tertiary-container: '#00624f'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdea6'
  primary-fixed-dim: '#f9bd3f'
  on-primary-fixed: '#271900'
  on-primary-fixed-variant: '#5e4200'
  secondary-fixed: '#dde2f0'
  secondary-fixed-dim: '#c1c7d3'
  on-secondary-fixed: '#161c25'
  on-secondary-fixed-variant: '#414752'
  tertiary-fixed: '#7ef8d5'
  tertiary-fixed-dim: '#60dbba'
  on-tertiary-fixed: '#002018'
  on-tertiary-fixed-variant: '#005140'
  background: '#f8fafb'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  headline-xl:
    fontFamily: Montserrat
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Montserrat
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Montserrat
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Montserrat
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 120px
---

## Brand & Style

The design system is engineered to evoke a sense of speed, joy, and premium reliability. It targets a modern, urban demographic that values efficiency without sacrificing aesthetic pleasure. 

The style is **High-Contrast Minimalist**. It leverages massive amounts of white space to let high-quality food and product photography serve as the primary visual driver. The interface feels "airy" and "bouncy," utilizing high-energy accents of yellow against a sophisticated charcoal base to ensure the UI feels both professional and approachable. Motion should be fluid, reinforcing the "delivery" aspect of the brand through sliding transitions and springy interactions.

## Colors

The palette is dominated by **Glovo Yellow**, used strategically for primary actions and brand moments. **Charcoal** provides the necessary weight for typography and structural elements, ensuring high legibility and a premium feel.

- **Primary (Yellow):** Used for CTA buttons, active states, and price highlights.
- **Secondary (Charcoal):** Used for headlines, body text, and heavy iconography.
- **Tertiary (Green):** Specifically reserved for "Success" states, discounts, and "Available Now" indicators.
- **Neutral (Soft Gray):** Used for background fills and subtle borders to prevent the interface from feeling "stark."
- **Surface (White):** All primary cards and containers sit on a pure white background to maximize cleanliness.

## Typography

This design system uses a dual-font strategy. **Montserrat** is used for headlines to provide a bold, geometric, and friendly character. For body text and functional labels, **Plus Jakarta Sans** is employed; its slightly wider stance and modern curves offer superior readability at small sizes while maintaining the system's "rounded" DNA.

Key instructions:
- Headlines should use tight letter-spacing to appear more impactful.
- Price displays should always use the `headline-md` or `headline-lg` weight to ensure they are the first thing a user sees on a card.
- Use `label-md` in all-caps for category headers to create a clear visual break.

## Layout & Spacing

The layout follows a **Fluid-Fixed Hybrid** model. On mobile, the system uses a 4-column grid with generous 20px side margins to ensure the content feels framed and high-end. On desktop, the content is capped at a 1280px max-width 12-column grid.

Spacing follows an 8px base unit. 
- Use **24px (md)** for vertical rhythm between distinct content blocks.
- Use **12px (sm)** for spacing within components (e.g., text to image in a card).
- Use **64px (xl)** to separate major sections like "Restaurants" from "Pharmacy" on the home screen.

## Elevation & Depth

Hierarchy is established through **Ambient Shadows** and tonal layering. This design system avoids harsh borders in favor of soft, diffused depth.

- **Level 1 (Base):** Subtle 1px border (#F2F4F5) for inactive or secondary elements.
- **Level 2 (Cards):** A soft shadow (Y: 4, Blur: 20, Opacity: 6% Black) is used for standard product cards.
- **Level 3 (Floating Actions):** A more pronounced shadow (Y: 8, Blur: 24, Opacity: 12% Black) is used for the "View Cart" button and floating navigation bars.
- **Level 4 (Modals):** Large blurs with a 20% backdrop dimming to focus user attention on checkout or item customization.

## Shapes

The shape language is "Hyper-Rounded." 
- **Standard Cards:** Use `rounded-lg` (16px) to create a friendly, safe appearance.
- **Buttons:** Use `rounded-xl` (24px) or full pill-shape for primary CTAs to make them feel highly "tappable" and distinct from content cards.
- **Images:** Photography must always follow the container’s corner radius; never use sharp-cornered images.
- **Input Fields:** Use `rounded-lg` (16px) to maintain consistency with the card language.

## Components

### Buttons
Primary buttons use the Glovo Yellow background with Charcoal text. They feature a subtle "push" animation on tap. Secondary buttons use a Charcoal outline or a light gray fill.

### Cards
Cards are the primary vehicle for content. Food photography should occupy the top 60% of the card, with a slight internal gradient overlay at the bottom to ensure white "delivery time" or "rating" badges are legible.

### Chips
Used for filtering (e.g., "Sushi," "Burgers," "Under 20 min"). These should be pill-shaped with a light gray background that turns Yellow when active.

### Lists
Order history and settings use clean, full-width rows separated by a 1px `neutral` divider. Each row should have a `chevron-right` icon in Charcoal to indicate drill-down capability.

### Inputs
Search bars and text fields use a subtle `neutral` fill with no border. On focus, they transition to a 2px Glovo Yellow border. Icons within inputs (like the search magnifying glass) should be Charcoal at 50% opacity.

### Featured "Bubble" Navigation
A signature component: circular icons for main categories (Food, Supermarket, Courier) with large, high-resolution icons or 3D renders sitting inside them, mimicking the recognizable circular navigation of top-tier delivery apps.