declare module "luamin" {
  export function minify(code: string | object): string;
  const luamin: { minify: typeof minify };
  export default luamin;
}
