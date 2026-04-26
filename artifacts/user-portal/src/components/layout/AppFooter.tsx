export function AppFooter() {
  return (
    <footer className="border-t border-border bg-card py-8 mt-auto">
      <div className="container mx-auto px-4 text-center text-sm text-muted-foreground">
        <p>© {new Date().getFullYear()} CryptoX. All rights reserved.</p>
      </div>
    </footer>
  );
}
